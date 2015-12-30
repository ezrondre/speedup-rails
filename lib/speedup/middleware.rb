module Speedup

  class Middleware

    def initialize(app)
      @app = app
      @redirects = []
    end

    def call(env)
      return @app.call(env) if !Speedup.enabled?

      Speedup.setup_request(env['action_dispatch.request_id'])
      status, headers, body = @app.call(env)
      Speedup.request.save

      if Speedup.show_bar? && headers['Content-Type'] =~ /text\/html/
        case status.to_i
        when 200..299, 400..500
          body = SpeedupBody.new(body, @redirects)
          # headers['Content-Length'] = body.collect{|row| row.length}.sum.to_s
          @redirects = []
        when 300..400
          @redirects.push(Speedup.request.id)
        end
      end

      [status, headers, body]
    rescue Exception => exception
       Speedup.request && Speedup.request.save
      raise exception
    end

    def speedup_request?(env)
      env['REQUEST_PATH'].starts_with?('/speedup_rails')
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
        @rack_body.close if @rack_body && @rack_body.respond_to?(:close)
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
              '<div id="speedup_rails_bar"></div>' +
              "<script>#{javascript}" +
              " loadRequestData('#{SpeedupRails::Engine.routes.url_helpers.result_path(Speedup.request.id)}');"
        @redirects.each_with_index do |req_id, idx|
          str << " loadRequestData('#{SpeedupRails::Engine.routes.url_helpers.result_path(req_id, redirect: idx)}');"
        end
        str << "if( typeof jQuery !== 'undefined' ) {
              jQuery(document).ajaxComplete(function(evt, xhr, settings){
                var request_id = xhr.getResponseHeader('X-Request-Id');
                if( request_id && !settings.url.match('#{SpeedupRails::Engine.routes.url_helpers.result_path('')}') )
                  loadRequestData('#{SpeedupRails::Engine.routes.url_helpers.result_path('REQUEST_ID')}'.replace('REQUEST_ID', request_id));
              });
            }"
        str << '</script>'
        str
      end

      private

        def styles
          <<-END_STYLES
            <style type="text/css">
              #speedup_rails_bar {
                position: fixed;
                bottom: 5px;
                right: 5px;
                min-width: 250px;
                z-index: 8;
              }
              #speedup_rails_bar .redirect {
                color: #444;
              }
              #speedup_rails_bar .speedup_main_bar,
              #speedup_rails_bar .additional_info
              {
                border: 1px solid #c9c9c9;
                background-color: #EDEAE0;
                border-radius: 3px;
                font-size: 14px;
                overflow: auto;
                font: normal normal 12px/21px Tahoma, sans-serif;
              }
              #speedup_rails_bar > ul.speedup_main_bar {
                list-style: none;
                clear: left;
                margin: 0;
                padding: 0;
                margin-left: 4px;
                overflow: visible;
                position: relative;
                height: 22px;
              }
              #speedup_rails_bar > ul > li { float: left; padding-left: 5px; }
              #speedup_rails_bar .additional_info {
                position: absolute;
                bottom: 100%;
                right: 0;
                padding: 5px;
                display: none;
                max-height: 500px;
                max-width: 200%;
                overflow: scroll;
              }
              #speedup_rails_bar > ul > li:hover .additional_info { display: block; }
              #speedup_rails_bar li > span { padding: 0 2px; margin-left: 20px; }
              #speedup_rails_bar .icon_container {
                position: relative;
              }
              #speedup_rails_bar .icon_container img {
                position: absolute;
                max-width: 100px;
              }
              #speedup_rails_bar .additional_info > div > div {
                border-bottom: 1px solid #c9c9c9;
              }
              #speedup_rails_bar .additional_info > div > div:last-child {
                border-bottom: none;
              }
              #speedup_rails_bar .additional_info .duration {
                font-weight: bold;
              }
              #speedup_rails_bar .additional_info .duration.duration-warning {
                color: red;
              }
              #speedup_rails_bar .additional_info .backtrace {
                font-size: 95%;
                margin: 5px 0 0 20px;
                line-height: 1.4em;
              }
              #speedup_rails_bar .additional_info .backtrace .backtrace_line:not(:first-child) {
                display: none;
              }
            </style>
          END_STYLES
        end

        def javascript
          result = <<-'END_JS'
            function loadRequestData(url) {
              speedup_rails_ajax( url , function(xhr) {
                res = stripScript( xhr.responseText );
                appendHtml(document.getElementById('speedup_rails_bar'), res[0]);
                executeScript(res[1]);
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
                  scriptElement.innerHTML = scripts;
                  head.appendChild(scriptElement);
                  head.removeChild(scriptElement);
              }
            }

            function speedup_rails_ajax(url, callback) {
              var xmlhttp;

              if (window.XMLHttpRequest) {
                xmlhttp = new XMLHttpRequest();
              } else {
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
