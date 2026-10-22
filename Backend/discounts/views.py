from rest_framework.viewsets import ModelViewSet

from .models import Discount
from .serializers import DiscountSerializer

<<<<<<< HEAD
=======
from decimal import Decimal

from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .serializers import DiscountValidationSerializer

>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f

class DiscountViewSet(ModelViewSet):

    queryset = Discount.objects.all()

<<<<<<< HEAD
    serializer_class = DiscountSerializer
=======
    serializer_class = DiscountSerializer





class DiscountValidationView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = DiscountValidationSerializer(
            data=request.data
        )
        serializer.is_valid(raise_exception=True)

        discount = serializer.validated_data['discount']
        order_amount = serializer.validated_data['order_amount']

        if discount.value_type == 'percentage':
            discount_amount = (
                order_amount * discount.value / Decimal('100')
            )

            if discount.max_discount is not None:
                discount_amount = min(
                    discount_amount,
                    discount.max_discount
                )
        else:
            discount_amount = discount.value

        discount_amount = min(discount_amount, order_amount)
        final_amount = order_amount - discount_amount

        return Response({
            'valid': True,
            'message': 'Promo code applied successfully.',
            'code': discount.code,
            'discount_amount': str(discount_amount),
            'final_amount': str(final_amount),
        }, status=status.HTTP_200_OK)
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
