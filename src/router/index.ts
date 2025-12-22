import { createRouter, createWebHistory } from 'vue-router';
import HomePage from '../components/HomePage.vue';
import SpecsPage from '../components/SpecsPage.vue';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomePage,
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
