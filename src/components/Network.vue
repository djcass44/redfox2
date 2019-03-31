<template>
    <v-layout>
        <v-flex xs12 sm6 offset-sm3>
            <div v-if="loading === true" class="text-xs-center pa-4">
                <v-progress-circular :size="50" color="accent" indeterminate></v-progress-circular>
            </div>
            <div class="text-xs-center pa-4" v-if="loading === false">
                <!-- <span v-if="online === true" color="grey darken-1"><v-icon color="green darken-2">signal_wifi_4_bar</v-icon>Connected</span> -->
                <span v-if="online === false" color="grey darken-1"><v-icon color="red darken-2">signal_wifi_off</v-icon>Offline</span>
            </div>
        </v-flex>
    </v-layout>
</template>
<script>
import ping from "web-pingjs";

export default {
    name: 'Network',
    data() {
        return {
            loading: true,
            online: true
        }
    },
    created() {
        let that = this;
        ping('https://google.com').then(r => {
            console.log("Established connection to google, we must have internet!");
            if(navigator.onLine)
                that.online = true;
            else
                that.online = false;
            setTimeout(function() {
                that.loading = false;
            }, 300);
            that.$emit('setNetwork', that.online); // Tell other components internet is available
        }).catch(err => {
            console.log("Failed to connect to google");
            console.log(err);
            that.online = false;
            setTimeout(function() {
                that.loading = false;
            }, 300);
            that.$emit('setNetwork', that.online); // Tell other components we are offline
        });
    }
};
</script>
