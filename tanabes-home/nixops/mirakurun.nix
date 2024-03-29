{
  services.mirakurun = {
    enable = true;
    tunerSettings = [
      {
        name = "PX4-S1";
        types = ["BS" "CS"];
        command = "recpt1 --b25 --device /dev/px4video0 <channel> - -";
        isDisabled = false;
      }
      {
        name = "PX4-S2";
        types = ["BS" "CS"];
        command = "recpt1 --b25 --device /dev/px4video1 <channel> - -";
        isDisabled = false;
      }
      {
        name = "PX4-S3";
        types = ["BS" "CS"];
        command = "recpt1 --b25 --device /dev/px4video4 <channel> - -";
        isDisabled = false;
      }
      {
        name = "PX4-S4";
        types = ["BS" "CS"];
        command = "recpt1 --b25 --device /dev/px4video5 <channel> - -";
        isDisabled = false;
      }
      {
        name = "PX4-T1";
        types = ["GR"];
        command = "recpt1 --b25 --device /dev/px4video2 <channel> - -";
        isDisabled = false;
      }
      {
        name = "PX4-T2";
        types = ["GR"];
        command = "recpt1 --b25 --device /dev/px4video3 <channel> - -";
        isDisabled = false;
      }
      {
        name = "PX4-T3";
        types = ["GR"];
        command = "recpt1 --b25 --device /dev/px4video6 <channel> - -";
        isDisabled = false;
      }
      {
        name = "PX4-T4";
        types = ["GR"];
        command = "recpt1 --b25 --device /dev/px4video7 <channel> - -";
        isDisabled = false;
      }
    ];
    channelSettings = import ./mirakurun/channel.nix;
  };
}
