module Cyrax::ControllerHelper
  def respond_with(*args)
    if args.present? && args.first.is_a?(Cyrax::Response)
      response, options = *args
      options = {
        notice: response.notice,
        error: response.error
      }.merge(options || {})

      # override status if needed
      options[:status] = response.status if response.status

      # convert result to model if possible
      result = response.result
      result = result.to_model if result.respond_to?(:to_model)

      # set flashes
      flash[:notice] = options[:notice] if options[:notice].present?
      flash[:error] = options[:error] if options[:error].present?
      set_resource_from(response)

      super(result, options) do |format|
        format.json do
          render json: response.as_json
        end
      end
    else
      super(*args)
    end
  end

  def set_resource_from(response)
    instance_variable_set("@#{response.resource_name}", response.result)
    response.assignments.each do |key, value|
      instance_variable_set("@#{key}", value)
    end if response.assignments.present? && response.assignments.is_a?(Hash)
  end
end
