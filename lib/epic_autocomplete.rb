module EpicAutocomplete
  
  module FormBuilderMethods

    # Options
    # :clear_button, show the clear button defaults to false
    # :callback, javascript function to call when something is selected
    # :clear_callback, javascript to call when input is cleared
    # :url, the url to call, defaults to /object.class/autocomplete.js
    # :display, what to view in field on an edit
    
    def autocomplete(method, options = {})
      autocomplete_class = options.delete(:autocomplete_class) || @object.class.to_s
      url                = options.delete(:url) || "/#{autocomplete_class.pluralize.downcase}/autocomplete.js"
      display            = options.delete(:display) || :id
      options[:class]    = options[:class] || 'autocomplete'
      clear_button       = options.delete(:clear_button) || false
      clear_button_text  = options.delete(:clear_button_text) || "Clr"

      # Create an id for all autocomplete objects
      options[:id] = "#{@object_name}_#{method}_autocomplete"

      # Callback after change
      callback       = options.delete(:callback) || ''
      clear_callback = options.delete(:clear_callback) || ''

      # Determine what the default value be
      begin
        value_object    = "#{autocomplete_class}".constantize.find(@object.send(method))
        options[:value] = "(#{value_object.id}) #{value_object.send(display)}"
        selected_id     = value_object.id
      rescue ActiveRecord::RecordNotFound, ActiveResource::ResourceNotFound
        value_object    = nil
        options[:value] = nil
        selected_id     = ''
      end
      
      # Doing the autocompleter this way ensures that the code will still work with javascript disabled
      new_fields = @template.text_field_tag("#{autocomplete_class}_#{method}", selected_id, options)
      if clear_button
        new_fields += %{<input type="button" value="#{clear_button_text}" id="#{options[:id]}_clear" class="autocomplete_clear" #{'disabled=true' unless options[:disabled].blank?} />}
      end
      new_fields += @template.hidden_field(@object_name, method, :id => "#{options[:id]}_hidden", :value => selected_id)

      @template.content_for(:head) do
        @template.javascript_tag do
          %{$(function(){
            $("##{options[:id]}").before('#{@template.escape_javascript(new_fields)}').remove();
            $("##{options[:id]}").addClass('autocomplete')
            .autocomplete("#{url}",
            {
              delay:250,
              minChars:2,
              selectFirst:1,
              formatItem: function(item) { return "(" + item[0] + ") " + item[1]; },
              formatResult: function(item) { return "(" + item[0] + ") " + item[1];},
              autoFill:true,
              mustMatch:true
            }
            )
            .result(function (evt, data, formatted) { $("##{options[:id]}_hidden").val(data[0]); #{callback}})
            .on_change(function(evt, value) { if(value == ''){$("##{options[:id]}_hidden").val(''); #{clear_callback}};});

            $("##{options[:id]}_clear").click(function () {
              $("##{options[:id]}_hidden").val('');
              $("##{options[:id]}").val('');
            });
          });}
        end
      end

      @template.text_field(@object_name, method, :id => "#{options[:id]}", :value => selected_id)
    end
  end 
end
