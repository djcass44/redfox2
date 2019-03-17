<template>
    <v-card class="m2-card">
        <p class="text-xs-center pa-2">You are in developer mode</p>
        <v-btn @click="this.$clearStorage">Reset Storage</v-btn>
    </v-card>
</template>
<script>
export default {
    name: 'Dev'
};
</script>
