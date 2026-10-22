<<<<<<< HEAD
from rest_framework.routers import DefaultRouter

from .views import DiscountViewSet

=======

from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import DiscountViewSet, DiscountValidationView
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f

router = DefaultRouter()

router.register(
    'discounts',
    DiscountViewSet,
    basename='discount'
)

<<<<<<< HEAD
urlpatterns = router.urls
=======
urlpatterns = [
    path(
        'validate/',
        DiscountValidationView.as_view(),
        name='discount-validate'
    ),
]

urlpatterns += router.urls
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
