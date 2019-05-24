<template>
  <v-app>
    <Toolbar
        @drawer="setDrawer"
        @showHelp="showHelp"></Toolbar>
    <Drawer ref="drawer"
        @showList="showList"
        @showHelp="showHelp"
        @showAbout="showAbout">
    </Drawer>
    <v-content>
      <List v-if="state === 0"
        @showHelp="showHelp"></List>
      <Help v-else-if="state === 1"
        @showList="showList"></Help>
      <About v-else-if="state === 2"
        @showList="showList"></About>
      <NotFound v-else></NotFound>
    </v-content>
  </v-app>
</template>

<script>
import List from './components/List';
import About from './components/pages/About.vue';
import Help from './components/pages/Help.vue';
import NotFound from './components/pages/NotFound.vue';

import Toolbar from './components/Toolbar';
import Drawer from './components/widgets/Drawer.vue';

export default {
    name: 'App',
    components: {
        List,
        About,
        Help,
        NotFound,
        Toolbar,
        Drawer
    },
    data () {
        return {
            state: 0
        }
    },
    methods: {
      // TODO use vue-router
        showList() {
            this.state = 0;
        },
        showHelp() {
            this.state = 1;
        },
        showAbout() {
            this.state = 2;
        },
        setDrawer(visible) {
            this.$refs.drawer.setVisible(visible);
        }
    }
}
</script>
