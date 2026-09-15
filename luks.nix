{ ... }: {
  luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/492b6364-d07e-4abf-9632-1cef99967724";
      preLVM = true;

      # Better read/write on SSD
      # https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
      bypassWorkqueues = true;
      allowDiscards = true;
    };
  };
}
