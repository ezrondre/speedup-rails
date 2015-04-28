module Speedup

  class Middleware

    def initialize(app)
      @app = app
      @redirects = []
    end

    def call(env)
      Speedup.setup_request(env['action_dispatch.request_id'])
      status, headers, body = @app.call(env)
      Speedup.request.save
      case status
      when 200..299
        if Speedup.show_bar? && body.is_a?(ActionDispatch::Response::RackBody)
          body = SpeedupBody.new(body, @redirects)
          headers['Content-Length'] = body.collect{|row| row.length}.sum.to_s
        end
        @redirects = []
      when 300..400
        @redirects.push(Speedup.request.id)
      end
      [status, headers, body]
    rescue Exception => exception
       Speedup.request && Speedup.request.save
      raise exception
    end

    class SpeedupBody
      include Enumerable

      def initialize(rack_body, redirects=[])
        @rack_body = rack_body
        @redirects = redirects
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
        str = "#{styles}" +
              '<div id="speed_up_rails_bar"></div>' +
              "<script>#{javascript}" +
              " loadRequestData('#{Speedup::Engine.routes.url_helpers.result_path(Speedup.request.id)}');"
        @redirects.each_with_index do |req_id, idx|
          str << " loadRequestData('#{Speedup::Engine.routes.url_helpers.result_path(req_id, redirect: idx)}');"
        end
        str << '</script>'
        str
      end

      private

        def styles
          <<-END_STYLES
            <style type="text/css">
              #speed_up_rails_bar,
              #speed_up_rails_bar .additional_info > div {
                position: fixed;
                bottom: 5px;
                right: 5px;
                min-width: 250px;
              }
              #speed_up_rails_bar .redirect {
                color: #444;
              }
              #speed_up_rails_bar .speed_up_main_bar,
              #speed_up_rails_bar .additional_info > div
              {
                border: 1px solid #c9c9c9;
                background-color: #EDEAE0;
                border-radius: 3px;
                font-size: 14px;
                overflow: auto;
                font: normal normal 12px/21px Tahoma, sans-serif;
              }
              #speed_up_rails_bar > ul { list-style: none; clear: left; margin: 0; padding: 0; margin-left: 4px; }
              #speed_up_rails_bar > ul > li { float: left; overflow: visible; }
              #speed_up_rails_bar li > span { padding: 0 4px; }
              #speed_up_rails_bar img {
                vertical-align: middle;
                position: relative;
                top: -1px;
                margin-right: 3px;
                width: 18px;
              }
              #speed_up_rails_bar .additional_info > div {
                padding: 5px;
                display: none;
              }
              #speed_up_rails_bar .additional_info > div > div {
                border-bottom: 1px solid #c9c9c9;
              }
              #speed_up_rails_bar .additional_info > div > div:last-child {
                border-bottom: none;
              }
            </style>
          END_STYLES
        end

        def javascript
          result = <<-'END_JS'
            function loadRequestData(url) {
              speed_up_rails_ajax( url , function(xhr) {
                res = stripScript( xhr.responseText );
                appendHtml(document.getElementById('speed_up_rails_bar'), res[0]);
                executeScript(res[1])
              });
            }
            function appendHtml(el, str) {
              var div = document.createElement('div');
              div.innerHTML = str;
              while (div.children.length > 0) {
                el.appendChild(div.children[0]);
              }
            }

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
