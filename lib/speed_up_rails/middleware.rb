module SpeedUpRails

  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      SpeedUpRails.setup_request(env['action_dispatch.request_id'])
      status, headers, body = @app.call(env)
      SpeedUpRails.request.save
      if SpeedUpRails.show_bar? && body.is_a?(ActionDispatch::Response::RackBody)
        body = SpeedUpRailsBody.new(body)
        headers['Content-Length'] = body.collect{|row| row.length}.sum.to_s
      end
      [status, headers, body]
    rescue Exception => exception
       SpeedUpRails.request && SpeedUpRails.request.save
      raise exception
    end

    class SpeedUpRailsBody
      include Enumerable

      def initialize(rack_body)
        @rack_body = rack_body
      end

      def each(*params, &block)
        @rack_body.each do |response_row|
          if response_row =~ /<\/body>/
            yield response_row.sub(/<\/body>/, bar_html+'</body>')
          else
            yield response_row
          end
        end
      end

      def body
        @rack_body.body.sub(/<\/body>/, bar_html+'</body>')
      end

      def close
        @rack_body.close
      end

      def respond_to?(method, include_private = false)
        if method.to_s == 'to_path'
          @rack_body.respond_to?(method)
        else
          super
        end
      end

      def to_path
        @rack_body.to_path
      end

      def to_a
        @rack_body.to_ary
      end

      def to_ary
        to_a
      end


      def bar_html
        '<div id="speed_up_rails_bar"></div>' +
        "<script>#{javascript} speed_up_rails_ajax( '#{SpeedUpRails::Engine.routes.url_helpers.result_path(SpeedUpRails.request.id)}' , function(xhr){ res = stripScript( xhr.responseText ); document.getElementById('speed_up_rails_bar').innerHTML = res[0]; executeScript(res[1]) });</script>"
      end

      private

        def javascript
          result = <<-'END_JS'
            function stripScript(text) {
              var scripts = '';
              var cleaned = text.replace(/<script[^>]*>([\s\S]*?)<\/script>/gi, function(){
                  scripts += arguments[1] + '\n';
                  return '';
              });
              return [cleaned, scripts];
            };
            function executeScript(scripts) {
              if (window.execScript){
                  window.execScript(scripts);
              } else {
                  var head = document.getElementsByTagName('head')[0];
                  var scriptElement = document.createElement('script');
                  scriptElement.setAttribute('type', 'text/javascript');
                  scriptElement.innerText = scripts;
                  head.appendChild(scriptElement);
                  head.removeChild(scriptElement);
              }
            }

            function speed_up_rails_ajax(url, callback) {
              var xmlhttp;

              if (window.XMLHttpRequest) {
                // code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp = new XMLHttpRequest();
              } else {
                // code for IE6, IE5
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
              }

              xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4 ) {
                  callback(xmlhttp);
                }
              }
              xmlhttp.open("GET", url, true);
              xmlhttp.send();
            }
          END_JS
          result.html_safe
        end
    end

  end

end
