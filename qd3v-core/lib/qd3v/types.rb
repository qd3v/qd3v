require 'dry-types'

module Types
  include Dry::Types()

  StrippedString  = Types::String.constructor(&:strip).freeze
  DowncasedString = StrippedString.constructor(&:downcase).freeze

  # REVIEW: I think we get String as result, not DateTime
  UTCDate = Types::String.constructor do |input|
    DateTime.parse(input).utc
  rescue ArgumentError
    raise Dry::Types::CoercionError,
          "#{input.inspect} cannot be coerced to DateTime"
  end.freeze

  # FAILED TO DEVELOP
  # UnixTimestamp = Coercible::Integer.constructor do |value|
  #   Time.at(value.to_i)
  # end
end
