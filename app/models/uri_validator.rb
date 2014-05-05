class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      uri = URI.parse(value)
      message = options[:message] || I18n.t('invalid_uri')
      record.errors.add(attribute, message) unless uri.absolute?
    rescue URI::InvalidURIError
      record.errors.add(attribute, message)
    end
  end
end
