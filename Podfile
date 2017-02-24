workspace 'Evocation.xcworkspace'

## Frameworks targets
abstract_target 'Frameworks' do
	use_frameworks!
	target 'Evocation-iOS' do
		platform :ios, '8.0'
	end

	target 'Evocation-watchOS' do
		platform :watchos, '2.0'
	end

	target 'Evocation-tvOS' do
		platform :tvos, '9.0'
	end

	target 'Evocation-OSX' do
		platform :osx, '10.9'
	end
end

## Tests targets
abstract_target 'Tests' do
	use_frameworks!

	pod 'Quick'
	pod 'Nimble'

	target 'EvocationTests-iOS' do
		platform :ios, '8.0'
	end

	target 'EvocationTests-tvOS' do
		platform :tvos, '9.0'
	end

	target 'EvocationTests-OSX' do
		platform :osx, '10.10'
	end
end

## Samples targets
abstract_target 'Samples' do
	use_frameworks!
	target 'EvocationSample-iOS' do
		project 'Samples/EvocationSample-iOS/EvocationSample-iOS'
		platform :ios, '8.0'
	end

	abstract_target 'watchOS' do
		project 'Samples/EvocationSample-watchOS/EvocationSample-watchOS'
		target 'EvocationSample-watchOS' do
			platform :ios, '8.0'
		end

		target 'EvocationSample-watchOS WatchKit Extension' do
			platform :watchos, '2.0'
		end
	end

	target 'EvocationSample-tvOS' do
		project 'Samples/EvocationSample-tvOS/EvocationSample-tvOS'
		platform :tvos, '9.0'
	end

	target 'EvocationSample-OSX' do
		project 'Samples/EvocationSample-OSX/EvocationSample-OSX'
		platform :osx, '10.9'
	end
end
