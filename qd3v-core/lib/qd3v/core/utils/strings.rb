module Qd3v
  module Core
    module Utils
      module Strings
        include SemanticLogger::Loggable

        # @deprecated not using anymore
        def self.md5_text(text)
          normalized = text.to_s.squish.downcase.gsub(/[^a-z0-9]/, '')
          logger.trace("Normalized string", normalized:)
          Digest::MD5.hexdigest(normalized)
        end

        # The biggest pain here is the `it's don't` preservation
        # (\s|^): Matches a whitespace character or the start of the string.
        # '(.*?)': Matches single quotes around the shortest non-greedy sequence of characters.
        # (\s|$|[.,!?]): Matches a whitespace character, end of the string, or punctuation (.,!?).
        # \1"\2"\3: Replaces the matched single quotes with double quotes, preserving the matched characters.

        def self.replace_single_quotes_with_double(text)
          # Consider word boundaries and exclude contractions or possessives
          text.gsub(/(\s|^)'(.*?)'(\s|$|[.,!?])/, '\1"\2"\3')
        end

        # Mostly for removing trailing dots
        def self.chomp_ending_dots(text)
          if text.end_with?('...')
            # Keep it unchanged if it ends with an ellipsis
            text
          elsif text.end_with?('..')
            # Change to an ellipsis if it ends with two dots
            text.gsub(/\.\.\z/, '...')
          elsif text.end_with?('.')
            # Remove a single dot at the end
            text.chomp('.')
          else
            # Return the text unchanged if it doesn't end with any dots
            text
          end
        end

        # @deprecated not used?
        def self.safe_enum_value(value)
          value.downcase.split('/').map(&:underscore).join('__')
        end
      end
    end
  end
end
