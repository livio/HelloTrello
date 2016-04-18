#
# Be sure to run `pod lib lint HelloTrello.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HelloTrello"
  s.version          = "0.1.3"
  s.summary          = "A Swift library to interact with the Trello API"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
    HelloTrello is a simple Swift API to interact with the Trello API. It uses auth-tokens and currenly only supports basic GET requests.
                       DESC

  s.homepage         = "https://github.com/livio/HelloTrello"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'BSD 3-Clause'
  s.author           = { "Joel Fischer" => "joeljfischer@gmail.com" }
  s.source           = { :git => "https://github.com/livio/HelloTrello.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'HelloTrello' => ['Pod/Assets/*.png']
  }

  s.dependency 'Alamofire', '~> 3.0'
  s.dependency 'AlamofireImage', '~> 2.0'
  s.dependency 'Decodable', '~> 0.4'
end
