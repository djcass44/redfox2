<template>
    <v-card v-if="devMode === true" class="m2-card">
        <p class="text-xs-center pa-2">You are in developer mode</p>
        <v-btn @click="this.$clearStorage">Reset Storage</v-btn>
    </v-card>
</template>
<script>
export default {
    name: 'Dev',
    data() {
        return {
            devMode: false
        }
    },
    created() {
        if(process.env.NODE_ENV === "development")
            this.devMode = true;
    }
};
</script>
