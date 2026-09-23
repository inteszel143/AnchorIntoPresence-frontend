import importlib.util
from pathlib import Path
import plistlib
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('build_release', Path(__file__).with_name('build_release.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ReleaseVersionTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.pubspec = self.root / 'pubspec.yaml'
        self.pubspec.write_text('name: example\nversion: 1.11.1+80\n')
        self.calls = []

    def run_build(self, command, **kwargs):
        self.calls.append(command)

    def test_both_platforms_share_one_increment_and_live_url(self):
        module.build_release(self.root, 'both', run=self.run_build)
        self.assertIn('version: 1.11.1+81', self.pubspec.read_text())
        self.assertEqual([call[2] for call in self.calls], ['appbundle', 'ipa'])
        for call in self.calls:
            self.assertIn('--build-number=81', call)
            self.assertIn('--dart-define=API_BASE_URL=https://admin.anchorintopresence.net', call)

    def test_subsequent_build_increments_and_new_version_is_explicit(self):
        module.build_release(self.root, 'android', run=self.run_build)
        module.build_release(self.root, 'ios', '1.12.0', run=self.run_build)
        self.assertIn('version: 1.12.0+82', self.pubspec.read_text())
        self.assertIn('--build-name=1.12.0', self.calls[-1])

    def test_failed_build_does_not_reuse_reserved_number(self):
        def fail(command, **kwargs):
            raise subprocess.CalledProcessError(1, command)
        with self.assertRaises(subprocess.CalledProcessError):
            module.build_release(self.root, 'ios', run=fail)
        module.build_release(self.root, 'ios', run=self.run_build)
        self.assertIn('--build-number=82', self.calls[-1])

    def test_invalid_version_does_not_modify_pubspec(self):
        before = self.pubspec.read_bytes()
        for version in ['bad', '1.0.0']:
            with self.assertRaises(ValueError):
                module.build_release(self.root, 'ios', version, run=self.run_build)
        self.assertEqual(self.pubspec.read_bytes(), before)

    def test_ios_reads_flutter_version_fields(self):
        path = Path(__file__).parents[1] / 'ios/Runner/Info.plist'
        info = plistlib.loads(path.read_bytes())
        self.assertEqual(info['CFBundleShortVersionString'], '$(FLUTTER_BUILD_NAME)')
        self.assertEqual(info['CFBundleVersion'], '$(FLUTTER_BUILD_NUMBER)')


if __name__ == '__main__':
    unittest.main()
