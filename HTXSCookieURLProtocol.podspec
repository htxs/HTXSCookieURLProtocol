Pod::Spec.new do |s|

  s.name                    = "HTXSCookieURLProtocol"
  s.version                 = "0.0.1"
  s.summary                 = "Synchronization Cookies with NSURLProtocol."

  s.homepage                = "https://github.com/htxs/HTXSCookieURLProtocol"

  s.license                 = { :type => "MIT", :file => "LICENSE" }

  s.authors                 = { "tianjie" => "gzucm_tianjie@foxmail.com" }

  s.ios.deployment_target   = "6.0"
  s.source                  = { :git => "https://github.com/htxs/HTXSCookieURLProtocol.git", :tag => s.version }
  s.source_files            = "HTXSCookieURLProtocol/*.{h,m}"
  s.requires_arc            = true

end
