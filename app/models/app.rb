class App < ActiveRecord::Base
  include Songkick::OAuth2::Model::ClientOwner

  belongs_to :user
  has_many :app_oauth_scopes, :dependent => :destroy
  has_many :oauth_scopes, :through => :app_oauth_scopes
#  has_many :app_activity_logs
  accepts_nested_attributes_for :app_oauth_scopes
  before_save :remove_parent_scope

  validates_presence_of :name, :slug, :redirect_uri
  validates :url, :uri => true, :allow_blank => true
  validates :redirect_uri, :uri => true, :allow_blank => true
  validates_inclusion_of :is_public, :in => [true, false]
  validates_uniqueness_of :slug, :scope => :deleted_at, :message => Proc.new { |a,b| "\"#{b[:value]}\" has already been taken" }

  before_validation :generate_slug
  after_create :create_oauth2_client
  after_update :update_oauth2_client

  attr_accessor :renew_secret
#  attr_accessible :name, :description, :short_description, :url, :logo, :redirect_uri, :app_oauth_scopes_attributes, :custom_text, :as => [:default, :admin]
#  attr_accessible :user, :user_id, :is_public, :as => :admin

  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "200x200>" }, :default_url => '/assets/app-icon.png'

  def self.default_scope
    where(:deleted_at => nil)
  end

  def self.deleted
    unscoped.where('deleted_at IS NOT NULL')
  end

  # Apps can only be deleted if they are not public and they do not have activity
  def can_delete?
    !self.is_public? && self.app_activity_logs.blank?
  end

  class << self
    def public
      where(:is_public => true)
    end

    def sandbox
      where(:is_public => false)
    end

    def default_app
      App.find_or_create_by_name("Default App", :redirect_uri => 'https://my.usa.gov')
    end

    def authentic_apps
      self.public.where("name != 'Default App'")
    end
  end

  def sandbox?
    !self.is_public
  end

  def redirect_uri=(uri)
    @redirect_uri = uri
  end

  def redirect_uri
    @redirect_uri.blank? ? (self.oauth2_client && self.oauth2_client.redirect_uri) : @redirect_uri
  end

  def client_id
    self.oauth2_client && self.oauth2_client.client_id
  end

  def oauth2_client
    @oauth2_client || self.oauth2_clients.first
  end

  def to_param
    self.slug
  end

  def find_scopes(scopes=nil)
    return [] if scopes.blank? || (!scopes.respond_to?(:to_a) && !scopes.respond_to?(:split))
    scopes = scopes.respond_to?(:to_a) ? scopes.to_a : scopes.split(" ")
    self.oauth_scopes.where("oauth_scopes.scope_name" => scopes)
  end

  def self.find_by_return_to_url(return_to_url)
    return nil unless return_to_url
    starts_with_http = return_to_url =~ /^http[s]*/
    starts_with_slash = return_to_url.starts_with?('/')
    client_id = nil
    if starts_with_http || starts_with_slash
      uri = URI.extract("#{'http://' if starts_with_slash}#{return_to_url}").try(:first)
      query = uri && URI.parse(uri).try(:query)
      client_id = query && (CGI.parse(query) || {})['client_id'].try(:first)
    end
    client_id && Songkick::OAuth2::Model::Client.find_by_client_id(client_id).try(:owner)
  end

  # def self.compare_domains(request_domain, app_url) # For apps/leaving
  #   app_uri        = Domainatrix.parse(app_url)
  #   request_domain = Domainatrix.parse(request_domain).domain_with_public_suffix
  #   if !!request_domain.match(/\.[a-zA-Z]{2,3}$/) # has public suffix. (not just 'localhost')
  #     if request_domain == app_uri.domain_with_public_suffix
  #       return false
  #     else
  #       return true
  #     end
  #   else
  #     return request_domain != app_uri.domain ? true : false
  #   end
  # end

  private

  def remove_parent_scope
    scopes = self.app_oauth_scopes
    scopes.each {|s| scopes.delete(s) if s.oauth_scope.is_parent? }
  end

  def generate_slug
    self.slug = self.name.parameterize if self.name
  end

  def create_oauth2_client
    @oauth2_client = Songkick::OAuth2::Model::Client.new(:name => self.name, :redirect_uri => @redirect_uri)
    @oauth2_client.oauth2_client_owner = self
    @oauth2_client.save
  end

  def update_oauth2_client
    client = self.oauth2_client
    return true if client.nil? || @redirect_uri.blank?
    client.redirect_uri = @redirect_uri
    client.save
  end
end
