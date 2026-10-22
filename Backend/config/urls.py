from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter


urlpatterns = [
    path('admin/', admin.site.urls),

    path('api/v1/accounts/', include('accounts.urls')),
    path('api/v1/products/', include('products.urls')),
    path('api/v1/core/', include('core.urls')),
    path('api/v1/cart/',include('cart.urls')),
<<<<<<< HEAD
=======
    path('api/v1/discounts/', include('discounts.urls')),
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
]

if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT
    )