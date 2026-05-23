{ inputs, ... }:

{
  flake.nixosModules.skillful = { config, lib, pkgs, ... }: let
    cfg = config.programs.skillful;
    
    skillRoot = {
      pi = ".pi/agent/skills";
      claude = ".claude/skills";
      codex = ".codex/skills";
      hermes = ".hermes/skills";
    };
  in {
    options.programs.skillful = with lib; {
      enabledAgents = mkOption {
        type = types.listOf (types.enum [ "pi" "codex" "claude" "hermes" ]);
        default = [];
        description = ''
          Choose for which agents the skills need to be installed.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "breakds";
        description = "The user for which user `skillful` is installed";
      };

      skills = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          The list of the skills (in this repo) that will be added to all agents.
        '';
      };
    };

    config = lib.mkIf (cfg.enabledAgents != []) {
      home-manager.users."${cfg.user}".home.file = let
        installSkill = { agent, skill }: let location = skillRoot."${agent}"; in {
          name = "${location}/${skill}";
          value = {
            source = ../skills/${skill};
          };
        };
      in lib.listToAttrs (lib.mapCartesianProduct installSkill {
        agent = cfg.enabledAgents;
        skill = cfg.skills;
      });
    };
  };
}
