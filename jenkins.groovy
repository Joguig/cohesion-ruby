job {
	name "web-cohesion-ruby"
	using "TEMPLATE-autobuild"
	scm {
		git {
			remote {
				github 'web/cohesion-ruby', 'ssh', 'git-aws.internal.justin.tv'
				credentials 'git-aws-read-key'
			}
			clean true
		}
	}
	steps {
		shell 'manta -v -f build.json'
	}
}