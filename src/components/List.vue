<template>
    <v-layout>
        <v-flex xs12 sm6 offset-sm3>
            <div v-if="loading === true" class="text-xs-center pa-4">
                <v-progress-circular :size="50" color="accent" indeterminate></v-progress-circular>
            </div>
            <v-alert type="info" outlined v-if="offline === true">
                You are offline.
            </v-alert>
            <v-subheader inset>
                <div v-if="filter !== ''">Documents ({{ filtered.length }} results)</div>
                <div v-if="filter === ''">Documents</div>
            </v-subheader>
            <v-card v-if="filtered.length > 0" class="m2-card">
                <v-list two-line subheader>
                    <v-slide-y-transition class="py-0" group>
                        <v-list-tile v-for="item in filtered" :key="item.name" avatar v-ripple @click="openAsContent(item)">
                            <v-list-tile-avatar color="indigo darken-2"><v-icon large dark>book</v-icon></v-list-tile-avatar>
                            <v-list-tile-content>
                                <v-list-tile-title>{{ item.name }}</v-list-tile-title>
                                <v-list-tile-sub-title>Last updated %1s</v-list-tile-sub-title>
                            </v-list-tile-content>
                        </v-list-tile>
                    </v-slide-y-transition>
                </v-list>
            </v-card>
        </v-flex>
    </v-layout>
</template>
<script>

import axios from "axios";

export default {
    name: 'List',
    data() {
        return {
            loading: false,
            offline: true,
            items: [],
            filtered: [],
            filter: '',
        }
    },
    methods: {
        filterItems() {
            // TODO do actual search stuff
            this.filtered = this.items;
        },
        downloadResource(uri) {
            let that = this;
            let name = uri.split("/").pop();
            axios({
                url: uri,
                method: 'GET',
                responseType: 'blob',
            }).then(r => {
                this.$setItem(name, r.data);
                console.log(name);
            }).catch(err => {
                console.log(err);
            });
        },
        openAsContent(item) {
            console.log(`Opening item: ${item.name}, ${item.data}`);
            let b = new Blob([item.data], {type: "application/pdf"});
            const data = window.URL.createObjectURL(b);
            const link = document.createElement('a');
            link.href = data;
            // TODO open in new window instead of downloading
            link.setAttribute('download', item.name);
            link.click();
            setTimeout(function() {
                window.URL.revokeObjectURL(data);
            }, 100); // Require by Firefox
        },
        loadOfflineResources() {
            this.loading = true;
            let that = this;
            this.$iterateStorage(function (value, key, i) {
                console.log([key, value]);
                that.items.push({
                    name: key,
                    data: value
                });
            }, err => {
                if(!err) {
                    console.log("Iteration has completed!");
                }
            });
            this.loading = false;
        },
        createInitResources() {
            this.$setItem('book1', 'test.pdf');

            this.loadOfflineResources();
        }
    },
    created() {
        this.filterItems();

        // this.$setStorageDriver(localforage.INDEXEDDB);
        this.downloadResource("http://s2.q4cdn.com/235752014/files/doc_downloads/test.pdf");
        this.createInitResources();
    }
};
</script>
