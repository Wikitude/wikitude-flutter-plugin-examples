package com.wikitude.wikitude_plugin;

public class BuildInformationResponse {

    private String buildConfiguration;
    private String buildNumber;
    private String buildDate;

    BuildInformationResponse(String buildConfiguration, String buildNumber, String buildDate) {
        this.buildConfiguration = buildConfiguration;
        this.buildNumber = buildNumber;
        this.buildDate = buildDate;
    }

}
