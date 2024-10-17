module Qd3v
  module Core
    module Utils
      RSpec.describe Strings do
        def do_replace(text)
          Strings.replace_single_quotes_with_double(text)
        end

        describe "#replace_single_quotes_with_double" do
          it do
            expect(do_replace(%(Who called 'Star Power'?)))
              .to eq(%(Who called "Star Power"?))
          end

          it do
            expect(do_replace(%(I'm Don't)))
              .to eq(%(I'm Don't))
          end

          it do
            expect(do_replace(%(Breakin' bad)))
              .to eq(%(Breakin' bad))
          end

          it do
            expect(do_replace(%('Freaking bloody')))
              .to eq(%("Freaking bloody"))
          end

          it do
            expect(do_replace(%(It's 'a test' for 'single quotes' in a 'sentence'.)))
              .to eq(%(It's "a test" for "single quotes" in a "sentence".))
          end

          it do
            expect(do_replace(%(In 'Live it's SNL!')))
              .to eq(%(In "Live it's SNL!"))
          end
        end
      end
    end
  end
end
