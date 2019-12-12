package com.wikitude.wikitude_plugin;

import com.wikitude.common.devicesupport.Feature;

import java.util.EnumSet;
import java.util.List;

class FeaturesHelper {

    private FeaturesHelper(){}

    static EnumSet<Feature> convertArFeatures(List<String> features) {
        EnumSet<Feature> featuresSet = EnumSet.noneOf(Feature.class);
        for(int i = 0; i < features.size(); i++) {
            switch (features.get(i)) {
                case "image_tracker": featuresSet.add(Feature.IMAGE_TRACKING);
                    break;
                case "instant_tracking": featuresSet.add(Feature.INSTANT_TRACKING);
                    break;
                case "object_tracking": featuresSet.add(Feature.OBJECT_TRACKING);
                    break;
                case "geo": featuresSet.add(Feature.GEO);
                    break;
            }
        }
        return featuresSet;
    }

}
