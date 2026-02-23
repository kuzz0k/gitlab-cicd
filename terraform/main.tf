resource "proxmox_virtual_environment_vm" "test_vm" {
  name      = "test-bpg-vm"
  node_name = "homelab"
  vm_id     = 200

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  clone {
    vm_id = 9000
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 10
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = "local"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [file("~/.ssh/id_rsa.pub")]
    }
  }
}
