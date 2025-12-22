import { createRouter, createWebHistory } from 'vue-router';
import HomePage from '../components/HomePage.vue';
import SpecsPage from '../components/SpecsPage.vue';
import DemoApp from '../components/DemoApp.vue';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomePage,
  },
  {
    path: '/demo',
    name: 'Demo',
    component: DemoApp,
  },
  {
    path: '/specs',
    name: 'Specs',
    component: SpecsPage,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
