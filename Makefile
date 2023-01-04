ARTIFACT_BUNDLE=secret-keys.artifactbundle
ARTIFACT_BUNDLE_INFO_TEMPLATE=artifact_info.json

.PHONY: build
build: .build/debug/secret-keys

.PHONY: release-build
release-build: .build/release/secret-keys

.PHONY: artifact
artifact: secret-keys.artifactbundle

.PHONY: test
test:
	swift test

.PHONY: lint
lint:
	mint run swiftlint Sources Tests

.PHONY: format
format:
	mint run swiftlint --fix Sources Tests

.build/debug/secret-keys: Package.swift Sources/**/*.swift
	swift build

.build/release/secret-keys: Package.swift Sources/**/*.swift
	swift build -c release --arch arm64 --arch x86_64

secret-keys.artifactbundle: .build/release/secret-keys LICENCE README.md
	rm -rf secret-keys.artifactbundle
	mkdir -p $(ARTIFACT_BUNDLE)/secret-keys/bin
	sed -e 's/__VERSION__/$(VERSION)/' $(ARTIFACT_BUNDLE_INFO_TEMPLATE) > $(ARTIFACT_BUNDLE)/info.json
	cp .build/release/secret-keys $(ARTIFACT_BUNDLE)/secret-keys/bin/
	cp LICENCE README.md $(ARTIFACT_BUNDLE)/secret-keys/
