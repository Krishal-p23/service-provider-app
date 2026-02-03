from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from accounts.services.verification import trigger_verification
from .serializers import SignupSerializer, GovIDUploadSerializer

class SignupView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"message": "Signup successful"})
    
        
class GovIDUploadView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request):
        worker = request.user.workerprofile

        serializer = GovIDUploadSerializer(
            worker,
            data=request.data,
            partial=True
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        trigger_verification(worker)

        return Response(
            {"message": "Gov ID uploaded, verification initiated"},
            status=200
        )
