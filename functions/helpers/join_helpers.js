function hasJoinCapacity(activity) {
  const currentParticipantCount = activity?.participantCount || 0;
  const maxParticipants = activity?.maxParticipants || 1;
  return (
    activity &&
    activity.status !== 'full' &&
    activity.status !== 'cancelled' &&
    activity.status !== 'completed' &&
    currentParticipantCount < maxParticipants
  );
}

function getJoinApprovalOutcome({ activity, request }) {
  if (!activity || !request) {
    return { allowSideEffects: false, workflowStatus: 'invalidMissingActivity' };
  }

  if (activity.ownerUserId === request.requesterId) {
    return {
      allowSideEffects: false,
      workflowStatus: 'invalidOwnerRequest',
      nextStatus: 'cancelled',
    };
  }

  if (!hasJoinCapacity(activity)) {
    return {
      allowSideEffects: false,
      workflowStatus: 'approvalCapacityBlocked',
    };
  }

  return { allowSideEffects: true };
}

module.exports = {
  getJoinApprovalOutcome,
  hasJoinCapacity,
};
