{ lib ,...}: with lib; {
  services.postgresql = {
    enable = true;
    ensureUsers = [{
       name = "forgejo";
         ensureDBOwnership = true;
       }];
     ensureDatabases = [ "forgejo" ];
  };

  services.forgejo = {
    enable = true;
#    lfs.enable = true;

  settings = {
/*    APP_NAME = "Forgejo";
    RUN_MODE = "prod";
    APP_SLOGAN = "Github, but oli";
    RUN_USER = "git";
    WORK_PATH = "/var/lib/forgejo/gitea";*/

    repository.ROOT = mkForce "/var/lib/forgejo/git/repositories";
    "repository.local".LOCAL_COPY_PATH = "/var/lib/forgejo/gitea/tmp/local-repo";
    "repository.upload".TEMP_PATH = "/var/lib/forgejo/gitea/uploads";
    "repository.pull-request".DEFAULT_MERGE_STYLE = "merge";
    "repository.signing".DEFAULT_TRUST_MODEL = "committer";

    server.APP_DATA_PATH = "/var/lib/forgejo/gitea";
    server.DOMAIN = "git.oliver-koss.at";
    server.SSH_DOMAIN = "git.oliver-koss.at";
    server.HTTP_PORT = 3000;
    server.ROOT_URL = "https://git.oliver-koss.at/";
    server.DISABLE_SSH = false;
    server.START_SSH_SERVER = false;
    server.SSH_PORT = 22;
    server.SSH_LISTEN_PORT = 22;
    server.LFS_START_SERVER = true;
    server.LFS_JWT_SECRET = "vUZNXwVQCewORR_Yx6wMDKkZ7hh8RKIv-S3DfqHKCTQ";
    server.OFFLINE_MODE = true;

    indexer.ISSUE_INDEXER_PATH = "/var/lib/forgejo/gitea/indexers/issues.bleve";

    session.PROVIDER_CONFIG = "/var/lib/forgejo/gitea/sessions";
    session.PROVIDER = "file";

    picture.AVATAR_UPLOAD_PATH = "/var/lib/forgejo/gitea/avatars";
    picture.REPOSITORY_AVATAR_UPLOAD_PATH = "/var/lib/forgejo/gitea/repo-avatars";

    attachment.PATH = "/var/lib/forgejo/gitea/attachments";

    log.MODE = "console";
    log.LEVEL = "Info";
    log.ROOT_PATH = "/var/lib/forgejo/gitea/log";

    security.INSTALL_LOCK = true;
    security.SECRET_KEY = "";
    security.REVERSE_PROXY_LIMIT = 1;
    security.REVERSE_PROXY_TRUSTED_PROXIES = "*";
    security.INTERNAL_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE3NDE5NjEyNzF9.qfhc4k-SgAig6f7eBN79TtNRyEvT0TBwQO5YVnqGgOw";
    security.PASSWORD_HASH_ALGO = "pbkdf2_hi";

    service.DISABLE_REGISTRATION = true;
    service.REQUIRE_SIGNIN_VIEW = false;
    service.REGISTER_EMAIL_CONFIRM = false;
    service.ENABLE_NOTIFY_MAIL = false;
    service.ALLOW_ONLY_EXTERNAL_REGISTRATION = false;
    service.ENABLE_CAPTCHA = false;
    service.DEFAULT_KEEP_EMAIL_PRIVATE = false;
    service.DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
    service.DEFAULT_ENABLE_TIMETRACKING = true;
    service.NO_REPLY_ADDRESS = "noreply.localhost";

    lfs.PATH = "/var/lib/forgejo/git/lfs";

    mailer.ENABLED = false;

    openid.ENABLE_OPENID_SIGNIN = true;
    openid.ENABLE_OPENID_SIGNUP = true;

    "cron.update_checker".ENABLED = true;

    oauth2.JWT_SECRET = "pncmUWTKRnjP4_rAfAe7z6u4tGMxo1OC2Xz1VeSAkvk";

    federation.ENABLED = true;
    federation.SHARE_USER_STATISTICS = true;
    federation.MAX_SIZE = 4;

    ui.DEFAULT_THEME = "forgejo-dark";
  };
    database = {
      type = "postgres";
      socket = "/run/postgresql";
      name = "forgejo";
      user = "forgejo";
    };
  };

}
