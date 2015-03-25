#!/usr/bin/env node
'use strict';

var fs = require('fs');
var path = require('path');
var argv = require('yargs').argv;
var command = argv._.shift();

var targetDir = findGitRoot(process.cwd());
if (!targetDir) {
  console.log('fatal: Not a git repository (or any of the parent directories): .git');
  process.exit();
}

var sourceFile = path.join(__dirname, '../post-commit.sh');
var targetFile = path.join(targetDir, '.git/hooks/post-commit');

switch (command) {
  case 'install':
      fs.linkSync(sourceFile, targetFile);
    break;
  case 'uninstall':
      fs.unlinkSync(targetFile);
    break;
  default:
    console.log('usage: git hydra install');
    console.log('   or: git hydra uninstall');
}

function findGitRoot(dir) {
  if (fs.existsSync(path.join(dir, '.git'))) {
    return dir;
  } else if (dir === '.') {
    return null;
  } else {
    return findGitRoot(path.dirname(dir))
  }
}
