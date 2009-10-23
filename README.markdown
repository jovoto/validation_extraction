Simple plugin to extract validations from active-record to use them with jquery.validate and jquery.metadata

Description
=====
It adds the validation rules with custom error messages into the form markup, query.validate (with jquery.metadata which is needed to read the markup)
reads them automaticly out. 
It requires the validation_reflection plugin (http://rubyforge.org/projects/valirefl/)

Setup
=====
    script/plugin install git://github.com/jovoto/

We are using it together with formtastic, that is what you need to add to formtastic:

    def input(method, options = {})
    ...
    options[:input_html] ||= {}
    if @object && @object.class.respond_to?(:reflect_on_validations_for) && self.respond_to?(:build_validations)
      options[:input_html][:class] = [build_validations(@object, method, options), options[:input_html][:class]].join(" ")
    end

It extracts :validates_presence_of, :validates_acceptance_of and validates_length_of validation rules
It also adds :validates_uniqueness_of, to get this working you need to add an check method to the responding controller, this method has to implement 
the uniqueness validation

[Tim Aßmann](http://devo.to)  
tassmann@jovoto.com  
