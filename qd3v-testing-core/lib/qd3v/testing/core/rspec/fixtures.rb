module Qd3v
  module Testing
    module Core
      module RSpec
        module Fixtures
          FIXTURES_DIR_PATH = Pathname.new(Dir.pwd).join('spec', 'fixtures')

          def fixtures_dir_path
            @dir_exists = FIXTURES_DIR_PATH.exist? unless instance_variable_defined?(:@dir_exists)

            return FIXTURES_DIR_PATH if @dir_exists

            raise("Fixtures dir '#{FIXTURES_DIR_PATH}' does not exists")
          end

          def read_fixture_file(*path)
            raise ArgumentError, "Fixture path is empty" if path.empty?
            fixtures_dir_path.join(*path).read
          end

          def read_json_fixture_file(*path, symbolize: true)
            Oj.load(read_fixture_file(*path), symbol_keys: symbolize)
          end
        end
      end
    end
  end
end
