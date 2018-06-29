class EmbedController < ApplicationController
  def index
    api_key = params[:api_key]
    organization = Organization.find_by(api_key: api_key)

    if api_key.present? && organization.present?
      @minified_js = minified_js_snipet(api_key)
    else
      render_bad_request "parameters are missing or invalid"
    end
  end

  private

  def minified_js_snipet(api_key)
    "\n" \
    "\t <script> \n" \
    "\t\t var req=new XMLHttpRequest,script=document.createElement('script')," \
    'link=document.createElement("link"),baseUrl="",' \
    "apiKey='#{api_key}';" \
    'script.type="text/javascript",script.async=!0,' \
    'script.onload=function(){var e=window._ace;e&&e.insertWidget({apiKey:apiKey})},' \
    'link.rel="stylesheet",link.type="text/css",link.media="all",req.responseType="json",' \
    'req.open("GET",baseUrl+"/packs/manifest.json",!0),' \
    'req.onload=function(){var e=document.getElementsByTagName("script")[0],t=req.response;link.href=baseUrl+t["client.css"],script.src=baseUrl+t["client.js"],e.parentNode.insertBefore(link,e),e.parentNode.insertBefore(script,e)},' \
    "req.send(); \n" \
    "\t </script>"
  end
end
