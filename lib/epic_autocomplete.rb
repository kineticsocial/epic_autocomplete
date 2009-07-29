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
      rescue ActiveRecord::RecordNotFound, ActiveResource::ResourceNotFound => e
        value_object    = nil
        options[:value] = nil
        selected_id     = ''
      end

      @template.content_for(:head) {
        @template.javascript_tag do
          %{$(function(){

            $("##{options[:id]}_clear").click(function () {
              $("##{options[:id]}_hidden").val('');
              $("##{options[:id]}").val('');
            });

            $("##{options[:id]}").autocomplete("#{url}",
            {
              delay:200,
              minChars:2,
              selectFirst:1,
              formatItem: function(item) { return "(" + item[0] + ") " + item[1]; },
              formatResult: function(item) { return "(" + item[0] + ") " + item[1];},
              autoFill:true,
              mustMatch:true
              
            }
            ).result(function (evt, data, formatted) { $("##{options[:id]}_hidden").val(data[0]); #{callback}}
            ).on_change(function(evt, value) { if(value == ''){$("##{options[:id]}_hidden").val(''); #{clear_callback}};});
         });}
        end
      }

      output = @template.text_field("", "#{autocomplete_class}_#{method}", options)
      output << @template.hidden_field(@object_name, method, :id => "#{options[:id]}_hidden", :value => selected_id)
      if clear_button
        output << %{<input type="button" value="Clr" id="#{options[:id]}_clear" class="autocomplete_clear" #{'disabled=true' unless options[:disabled].blank?}>}
      end
      output
    end
  end 
end
