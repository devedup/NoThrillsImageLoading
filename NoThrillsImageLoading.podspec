Pod::Spec.new do |s|
    s.name     = 'NoThrillsImageLoading'
    s.version  = '1.0.19'

    s.license  = { :type => 'BSD license with attribution', :file => 'SourceCodeLicense.txt' }
    s.summary  = 'NoThrillsImageLoading - image loading with no thrills attached'
    s.homepage = 'https://github.com/devedup/NoThrillsImageLoading'
    s.author   = { 'David Casserly' => 'nothrills@devedup.com' }
    s.source   = { :git => 'https://github.com/devedup/NoThrillsImageLoading.git', :tag => "v#{s.version}" }

    s.swift_versions = ['4.2', '5']
    s.ios.deployment_target = '9.0'
    s.osx.deployment_target = '10.9'
    s.tvos.deployment_target = '9.0'
    s.source_files = 'Classes', 'Classes/**/*.swift'
end

