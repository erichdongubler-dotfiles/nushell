# A polyfill script for OpenSSH's `ssh-copy-id`.
export def main [
  where: string,
] {
  bat ~/.ssh/id_ed25519.pub | ssh $where "mkdir ~/.ssh; sh -c 'cat >> ~/.ssh/authorized_keys'"
}
