class Store
  attr_accessor :size, :availableIds

  def initialize(options = {})
    @size = options[:size]
    @availableIds = Array.new(size, false)
  end

  def remove(id)
    availableIds[id] = false
  end

  def allocateId
    id = getAvailableId
    availableIds[id] = true
    id
  end

  private

  def getAvailableId
    availableIds.size.times do |i|
      return i if !availableIds[i]
    end

    abort("No available switches.")
  end
end
