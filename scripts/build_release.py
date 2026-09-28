#!/usr/bin/env python3
"""Build store artifacts using separate, persistent platform version records."""
import argparse
import fcntl
import json
from pathlib import Path
import re
import shutil
import subprocess


def build_release(root, target, version=None, flutter="flutter", run=subprocess.run):
    lock_dir = root / '.dart_tool'
    lock_dir.mkdir(exist_ok=True)
    with (lock_dir / 'release-build.lock').open('w') as lock:
        # Hold the lock through the build so a concurrent release cannot change
        # pubspec while Flutter is reading it.
        fcntl.flock(lock, fcntl.LOCK_EX)
        records_path = root / 'release_versions.json'
        if records_path.exists():
            records = json.loads(records_path.read_text())
            platforms = ['android', 'ios'] if target == 'both' else [
                'android' if target == 'apk' else target]
            pending = []
            for platform in platforms:
                previous = records[platform][-1]
                parts = list(map(int, previous['version'].split('.')))
                parts[2] += 1
                next_version = version or '.'.join(map(str, parts))
                if not re.fullmatch(r'\d+\.\d+\.\d+', next_version):
                    raise ValueError('Version must be major.minor.patch')
                if tuple(map(int, next_version.split('.'))) < tuple(map(int, previous['version'].split('.'))):
                    raise ValueError('Release version cannot decrease')
                pending.append((platform, {
                    'version': next_version,
                    'build': previous['build'] + 1,
                    'status': 'reserved',
                }))
            def save_records():
                temporary = records_path.with_suffix('.json.tmp')
                temporary.write_text(json.dumps(records, indent=2) + '\n')
                temporary.replace(records_path)
            for platform, entry in pending:
                records[platform].append(entry)
            save_records()
            for platform, entry in pending:
                artifact = 'ipa' if platform == 'ios' else ('apk' if target == 'apk' else 'appbundle')
                print(f"Reserved {platform} {entry['version']} ({entry['build']})", flush=True)
                run([flutter, 'build', artifact, '--release',
                     f"--build-name={entry['version']}", f"--build-number={entry['build']}",
                     '--dart-define=API_BASE_URL=https://admin.anchorintopresence.net'],
                    cwd=root, check=True)
                entry['status'] = 'built'
                save_records()
            return
        pubspec = root / 'pubspec.yaml'
        source = pubspec.read_bytes().decode('utf-8')
        pattern = r'(?m)^(version:\s*)(\d+\.\d+\.\d+)\+(\d+)([ \t]*(?:#[^\r\n]*)?)(\r?)$'
        matches = list(re.finditer(pattern, source))
        if len(matches) != 1:
            raise ValueError('Expected one pubspec version: major.minor.patch+number')
        match = matches[0]
        old_version = match[2]
        version = version or old_version
        if not re.fullmatch(r'\d+\.\d+\.\d+', version):
            raise ValueError('Version must be major.minor.patch, for example 1.12.0')
        if tuple(map(int, version.split('.'))) < tuple(map(int, old_version.split('.'))):
            raise ValueError('Release version cannot decrease')
        number = int(match[3]) + 1
        updated = f'{match[1]}{version}+{number}{match[4]}{match[5]}'
        pubspec.write_bytes((source[:match.start()] + updated + source[match.end():]).encode('utf-8'))
        print(f'Reserved release version {version}+{number}', flush=True)
        # Keep this increment even on failure: a partial multi-platform build
        # may already have produced an artifact with this number.
        targets = ['appbundle', 'ipa'] if target == 'both' else [
            {'android': 'appbundle', 'ios': 'ipa', 'apk': 'apk'}[target]]
        for artifact in targets:
            run([flutter, 'build', artifact, '--release',
                 f'--build-name={version}', f'--build-number={number}',
                 '--dart-define=API_BASE_URL=https://admin.anchorintopresence.net'],
                cwd=root, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=['android', 'ios', 'both', 'apk'])
    parser.add_argument('--version', help='Public release version, e.g. 1.12.0')
    args = parser.parse_args()
    flutter = shutil.which('flutter')
    if not flutter:
        parser.error('Flutter is not on PATH; no version was changed')
    try:
        build_release(Path(__file__).resolve().parents[1], args.target, args.version, flutter)
    except ValueError as error:
        parser.error(str(error))
    except subprocess.CalledProcessError as error:
        parser.exit(error.returncode, 'Build failed. The reserved build number is retained.\n')


if __name__ == '__main__':
    main()
