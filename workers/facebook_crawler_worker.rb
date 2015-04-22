require 'fb_graph'
require 'pp'
require 'oauth'


oauth_access_token = "CAACEdEose0cBAHlASonjSYwa34bytRCS3Q74uMbRtDZBllY3pmgS8vNjKKEjZCtmZAyhSHtrGCMUEdwUBkUJy21Iq79ukw2U1MUlodUSd9HSJT6cdOe56ZAUq4x23KGqIYkQXPd35n9exI743NueSFNxwb77mPcWgbzjyjv3jdR0Me8t2COLudwZCnz2yi2hOZCsHqgNEJsHCZCxzvHyYqev5PlWLXtIkgZD"
user = FbGraph::User.search('Airouche',:access_token => oauth_access_token)
pp user
