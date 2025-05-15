zabbix_cli.auth][None][WARNING][auth.py:116 login]: Failed to log in with _get_username_password_config: ('Failed to log out of Zabbix API: %s', ZabbixAPIRequestError('Error: Invalid request.: Invalid parameter "/": unexpected parameter "auth".')): (-32600) Invalid request. Invalid parameter "/": unexpected parameter "auth".


               raise ZabbixAPIRequestError(
                    f"Failed to log in to Zabbix API: {e}"
                ) from e
            else:
                self.auth = str(auth) if auth else ""
                self.use_api_token = False

        self.ensure_authenticated()
        return self.auth

    def ensure_authenticated(self) -> None:
        """Test an authenticated Zabbix API session."""
        try:
            self.host.get(output=["hostid"], limit=1)
        except Exception as e:
            self.logout()
            raise ZabbixAPICallError("Failed to connect to Zabbix API") from e

    def logout(self) -> None:
        if not self.auth:
            return  # nothing to do

        # Technically this API endpoint might return `false`, which
        # would signify that that the logout somehow failed, but it's
        # not documented in the API docs - only the inverse case `true` is.
        try:
            self.user.logout()
        except ZabbixAPITokenExpired:
            pass
        except ZabbixAPIRequestError as e:
            raise ZabbixAPICallError("Failed to log out of Zabbix API: %s", e) from e
        self.auth = ""

    def confimport(self, format: ExportFormat, source: str, rules: ImportRules) -> Any:
        """Alias for configuration.import because it clashes with
        Python's import reserved keyword
        """
        return self.do_request(
            method="configuration.import",
            params={
                "format": format,
                "source": source,
                "rules": rules.model_dump_api(),
            },
        ).result

    # TODO (pederhan): Use functools.cachedproperty when we drop 3.7 support
    @property
    def version(self) -> Version:
        """Alternate version of api_version() that caches version info
        as a Version object.
        """
        if self._version is None:
            self._version = self.api_version()
        return self._version

    def api_version(self) -> Version:
        """Get the version of the Zabbix API as a Version object."""
