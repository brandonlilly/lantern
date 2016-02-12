class HouseFormatter < RSpec::Core::Formatters::DocumentationFormatter
   RSpec::Core::Formatters.register self, :example_pending

   def example_pending(notification)
   end

   def dump_pending(arg)
   end
end
