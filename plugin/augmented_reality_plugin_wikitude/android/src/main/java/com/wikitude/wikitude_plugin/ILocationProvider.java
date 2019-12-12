package com.wikitude.wikitude_plugin;

interface ILocationProvider {

    /**
     * Call when host-activity is resumed (usually within systems life-cycle method)
     */
    void onResume();

    /**
     * Call when host-activity is paused (usually within systems life-cycle method)
     */
    void onPause();

}
