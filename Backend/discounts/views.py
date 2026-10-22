from rest_framework.viewsets import ModelViewSet

from .models import Discount
from .serializers import DiscountSerializer

from decimal import Decimal

from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .serializers import DiscountValidationSerializer


class DiscountViewSet(ModelViewSet):

    queryset = Discount.objects.all()

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
