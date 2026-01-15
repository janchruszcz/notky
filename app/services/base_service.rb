# frozen_string_literal: true

class BaseService
  Result = Struct.new(:success?, :data, :error, keyword_init: true) do
    def failure?
      !success?
    end
  end

  def self.call(...)
    new(...).call
  end

  private

  def success(data = nil)
    Result.new(success?: true, data:, error: nil)
  end

  def failure(error)
    Result.new(success?: false, data: nil, error:)
  end
end
