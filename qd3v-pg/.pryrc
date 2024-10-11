puts "Loading pry"

require "amazing_print"
AmazingPrint.pry!

require 'qd3v/pg'

Qd3v::DI.finalize!

DB = Qd3v::DI[:pg]

def v
  DB.exec("SELECT version() pg_version").first.fetch("pg_version")
end

root_module = ::Qd3v::PG

# Add hook to change context to the specified module when Pry starts.
Pry.config.hooks.add_hook(:when_started,
                          :cd_into_module) do |_output, _binding, pry|
  if root_module
    pry.binding_stack.clear
    pry.push_binding(root_module)
    pry.pager.page "Changed context to: #{root_module}"
    pry.pager.page "Type 'v' to get server version"
  else
    pry.pager.page "Warning: Module #{root_module} not defined"
  end
end
