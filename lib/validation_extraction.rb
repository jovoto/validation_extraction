module ValidationExtraction
  def build_validations(object, method, options)
    if object.class.respond_to? :reflect_on_validations_for
      json = {}
      object.class.reflect_on_validations_for(method).each do |v|
        case v.macro
        when :validates_presence_of, :validates_acceptance_of then
          add_validations(json, :rules, "required: true")
          add_validations(json, :messages, "required: '#{v.options[:message]}'") if has_message?(v) 

        # default action is check for remote, if controller implements check
        when :validates_uniqueness_of then
          if controller = (find_controller_to_model(object.class.to_s) || find_controller_to_model(object.class.to_s.pluralize))
            if controller.method_defined?(:check)
              add_validations(json, :rules, "remote: '#{template.url_for({:controller => controller.controller_path, :action => "check"})}'")
              add_validations(json, :messages, "remote: '#{v.options[:message]}'")  if has_message?(v)
            end
          end

        # when :validates_confirmation_of then
        #   add_validations(json, :rules, "equalTo: '##{@object.class.to_s.downcase}_#{method}_confirmation'")
        #   add_validations(json, :messages, "equalTo: \"#{v.options[:message]}\"") if v.options[:message]
          
        when :validates_length_of   then
          if v.options[:minimum]
            add_validations(json, :rules, "minlength: #{v.options[:minimum]}")
            add_validations(json, :messages, "minlength: '#{v.options[:message]}'") if has_message?(v)
          elsif v.options[:maximum]
            add_validations(json, :rules, "maxlength: #{v.options[:maximum]}")
            add_validations(json, :messages, "maxlength: '#{v.options[:message]}'") if has_message?(v)
          elsif v.options[:within]
            add_validations(json, :rules, "rangelength: [#{v.options[:within].first}, #{v.options[:within].last}]")
            add_validations(json, :messages, "rangelength: '#{v.options[:message]}'") if has_message?(v)
          end
        end
      end
      return json[:rules].blank? ? "" : "{ #{json[:rules]} , messages:{#{json[:messages]}} }" 
    end
  end
 
  private

  def find_controller_to_model(controller_name)
    begin
      controller_name.concat("Controller").constantize
    rescue NameError
      false
    end
  end

  def has_message?(v)
    true unless v.options.blank? or v.options[:message].blank?
  end

  def add_validations(json, type, message = "")
    json[type.to_sym] = [json[type.to_sym], message].compact * ' , '
  end
end
