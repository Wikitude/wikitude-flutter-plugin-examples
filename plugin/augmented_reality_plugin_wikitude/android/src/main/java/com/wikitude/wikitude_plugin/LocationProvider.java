package com.wikitude.wikitude_plugin;

import android.annotation.SuppressLint;
import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.widget.Toast;

class LocationProvider implements ILocationProvider {

    /** location listener called on each location update */
    private final LocationListener locationListener;

    /** system's locationManager allowing access to GPS / Network position */
    private final LocationManager locationManager;

    /** location updates should fire approximately every second */
    private static final int LOCATION_UPDATE_MIN_TIME_GPS = 1000;

    /** location updates should fire, even if last signal is same than current one (0m distance to last location is OK) */
    private static final int LOCATION_UPDATE_DISTANCE_GPS = 0;

    /** location updates should fire approximately every second */
    private static final int LOCATION_UPDATE_MIN_TIME_NW = 1000;

    /** location updates should fire, even if last signal is same than current one (0m distance to last location is OK) */
    private static final int LOCATION_UPDATE_DISTANCE_NW = 0;

    /** to faster access location, even use 10 minute old locations on start-up */
    private static final int LOCATION_OUTDATED_WHEN_OLDER_MS	= 1000 * 60 * 10;

    /** is gpsProvider and networkProvider enabled in system settings */
    private boolean	gpsProviderEnabled, networkProviderEnabled;

    /** the context in which we're running */
    private final Context context;

    LocationProvider(final Context context, LocationListener locationListener) {
        super();
        this.locationManager = (LocationManager)context.getSystemService( Context.LOCATION_SERVICE );
        this.locationListener = locationListener;
        this.context = context;
        this.gpsProviderEnabled = this.locationManager.isProviderEnabled( LocationManager.GPS_PROVIDER );
        this.networkProviderEnabled = this.locationManager.isProviderEnabled( LocationManager.NETWORK_PROVIDER );
    }

    @SuppressLint("MissingPermission")
    @Override
    public void onPause() {
        if (this.locationListener != null && this.locationManager != null && (this.gpsProviderEnabled || this.networkProviderEnabled)) {
            this.locationManager.removeUpdates( this.locationListener );
        }
    }

    @SuppressLint("MissingPermission")
    @Override
    public void onResume() {
        if (this.locationManager != null && this.locationListener != null) {
            // check which providers are available are available
            this.gpsProviderEnabled = this.locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            this.networkProviderEnabled = this.locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);

            // is GPS provider enabled?
            if (this.gpsProviderEnabled) {
                final Location lastKnownGPSLocation = this.locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
                if (lastKnownGPSLocation != null && lastKnownGPSLocation.getTime() > System.currentTimeMillis() - LOCATION_OUTDATED_WHEN_OLDER_MS) {
                    locationListener.onLocationChanged(lastKnownGPSLocation);
                }
                this.locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, LOCATION_UPDATE_MIN_TIME_GPS, LOCATION_UPDATE_DISTANCE_GPS, this.locationListener);
            }

            // is Network / WiFi positioning provider available?
            if (this.networkProviderEnabled) {
                final Location lastKnownNWLocation = this.locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                if (lastKnownNWLocation != null && lastKnownNWLocation.getTime() > System.currentTimeMillis() - LOCATION_OUTDATED_WHEN_OLDER_MS) {
                    locationListener.onLocationChanged(lastKnownNWLocation);
                }
                this.locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, LOCATION_UPDATE_MIN_TIME_NW, LOCATION_UPDATE_DISTANCE_NW, this.locationListener);
            }

            // user didn't check a single positioning in the location settings, recommended: handle this event properly in your app, e.g. forward user directly to location-settings, new Intent( Settings.ACTION_LOCATION_SOURCE_SETTINGS )
            if (!this.gpsProviderEnabled && !this.networkProviderEnabled) {
                Toast.makeText(this.context, "Please enable GPS and Network positioning in your Settings ", Toast.LENGTH_LONG).show();
            }
        }
    }
}
