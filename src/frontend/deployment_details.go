package main

import (
	"os"
	"time"

	"github.com/sirupsen/logrus"
)

var deploymentDetailsMap map[string]string
var log *logrus.Logger

func init() {
	initializeLogger()
	loadDeploymentDetails()
}

func initializeLogger() {
	log = logrus.New()
	log.Level = logrus.DebugLevel
	log.Formatter = &logrus.JSONFormatter{
		FieldMap: logrus.FieldMap{
			logrus.FieldKeyTime:  "timestamp",
			logrus.FieldKeyLevel: "severity",
			logrus.FieldKeyMsg:   "message",
		},
		TimestampFormat: time.RFC3339Nano,
	}
	log.Out = os.Stdout
}

func loadDeploymentDetails() {
	podHostname := os.Getenv("POD_NAME")
	if podHostname == "" {
		var err error
		podHostname, err = os.Hostname()
		if err != nil {
			log.WithError(err).Warn("Failed to determine the frontend pod name")
		}
	}

	clusterName := os.Getenv("CLUSTER_NAME")
	if clusterName == "" {
		clusterName = "local"
	}

	region := os.Getenv("AWS_REGION")
	if region == "" {
		region = "local"
	}

	deploymentDetailsMap = map[string]string{
		"HOSTNAME":    podHostname,
		"CLUSTERNAME": clusterName,
		"REGION":      region,
	}

	log.WithFields(logrus.Fields{
		"cluster":  clusterName,
		"region":   region,
		"hostname": podHostname,
	}).Debug("Loaded AVOS deployment details")
}
